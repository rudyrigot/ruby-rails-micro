class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Rescue OAuth errors for some actions
  rescue_from Prismic::API::PrismicWSAuthError, with: :redirect_to_signin,
                                                 only: [:index, :download, :dochome, :doc, :docsearch, :getinvolved]

  def index
    @document = PrismicService.get_document(api.bookmark("homepage"), api, ref)
    @arguments = api.form("arguments")
                    .orderings("[my.argument.priority desc]")
                    .submit(ref)
    @ctas = api.form("ctas")
    				.orderings("[my.cta.priority desc]")
                    .submit(ref)
    @references = api.form("references")
                    .submit(ref)
  end

  def download
    @document = PrismicService.get_document(api.bookmark("download"), api, ref)

    # Doing a little dance with the GitHub API, from the Embed fragment: getting all recent assets
    if (@document['download.github'] && @document['download.github'].o_embed_json && @document['download.github'].o_embed_json['title'])
      # Getting the user name and repo name from the Embed fragment
      github_fullreponame = @document['download.github'].o_embed_json['title']
      github_username = github_fullreponame.split('/')[0]
      github_reponame = github_fullreponame.split('/')[1]

      # Retrieving the repo's releases information
      releases = (Github::Repos.new.releases per_page: 10).all owner: github_username, repo: github_reponame

      if (releases.size > 0)
        # Sorting the releases
        sorted_releases = releases.sort{|release1, release2| Date.parse(release2['created_at']) <=> Date.parse(release1['created_at']) }

        # On the one hand: getting the current latest release's assets
        latest_release = sorted_releases.shift
        latest_version_number = latest_release['tag_name']
        @latest_version_assets = latest_release['assets'].map do |asset|
          {name: asset['name'], size: asset['size'], url: "https://github.com/#{github_username}/#{github_reponame}/releases/download/#{latest_version_number}/#{asset['name']}"}
        end

        # On the other hand: getting the 10 previous assets from previous releases
        @other_versions_assets = sorted_releases.map { |release|
          tag_name = release['tag_name']
          release['assets'].map { |asset|
            {name: asset['name'], size: asset['size'], url: "https://github.com/#{github_username}/#{github_reponame}/releases/download/#{tag_name}/#{asset['name']}"}
          }
        }.flatten.first(10)
      end
    end
  end

  def dochome
    @docchapters = api.form("doc").query(%([[:d = at(document.type, "docchapter")]])).orderings('[my.docchapter.priority desc]').submit(ref)
    if @docchapters.length == 0
      render inline: "You need to have at least one documentation chapter published", status: :not_found
    else
      redirect_to doc_path(@docchapters[0].id, @docchapters[0].slug, ref: maybe_ref)
    end
  end

  def doc
    id = params[:id]
    slug = params[:slug]

    @document = PrismicService.get_document(id, api, ref)

    # This is how an URL gets checked (with a clean redirect if the slug is one that used to be right, but has changed)
    # Of course, you can change slug_checker in prismic_service.rb, depending on your URL strategy.
    @slug_checker = PrismicService.slug_checker(@document, slug)
    if !@slug_checker[:correct]
      render status: :not_found, file: "#{Rails.root}/public/404", layout: false if !@slug_checker[:redirect]
      redirect_to doc_path(id, @document.slug), status: :moved_permanently if @slug_checker[:redirect]
    else
      # Getting sub-documentations in the chapter, and replacing the serialization of their headers.
      @docs = @document['docchapter.docs'].map{ |group| PrismicService.get_document(group['linktodoc'], api, ref) }
      @docs.each {|doc|
        PrismicService.lower_html_heading(doc)
      }

      # Getting all chapters (for the left navigation)
      @docchapters = api.form('everything')
                        .query('[[:d = at(document.type, "docchapter")]]')
                        .orderings('[my.docchapter.priority desc]')
                        .submit(ref)
    end
  end

  def docsearch
  	@documents = api.form("doc")
                    .query(%([[:d = fulltext(document, "#{params[:q]}")]]))
                    .submit(ref)

    # Getting all chapters (for the left navigation)
    @docchapters = api.form('everything')
                      .query('[[:d = at(document.type, "docchapter")]]')
                      .orderings('[my.docchapter.priority desc]')
                      .submit(ref)
  end

  def getinvolved
    @document = PrismicService.get_document(api.bookmark("getinvolved"), api, ref)

    @contributors = api.form('contributors').orderings('[my.contributor.level]').submit(ref)
  end


  private

  # Used to rescue issues PrismicWSErrors in controller actions
  def redirect_to_signin
    redirect_to signin_path
  end


  # Returning the actual ref id being queried, even if it's the master ref.
  # To be used to call the API, for instance: api.form('everything').submit(ref)
  def ref
    @ref ||= maybe_ref || api.master_ref.ref
  end

  # Returning the ref id being queried, or nil if it is the master ref.
  # To be used where you want nothing if on master, but something if on another release.
  # For instance:
  #  * you can use it to call Rails routes: document_path(ref: maybe_ref), which will add "?ref=refid" as a param, but only when needed.
  #  * you can pass it to your link_resolver method, which will use it accordingly.
  def maybe_ref
    @maybe_ref ||= (params[:ref].blank? ? nil : params[:ref])
  end

  ##

  # Easier access and initialization of the Prismic::API object.
  def api
    @api ||= PrismicService.init_api(access_token)
    rescue Prismic::API::PrismicWSAuthError => e
      reset_access_token!
    raise e
  end

  def access_token
    @access_token = session['ACCESS_TOKEN']
  end

  def reset_access_token!
    @access_token = session['ACCESS_TOKEN'] = nil
  end

end
