module PrismicService
  class << self

    # Easier reading in the prismic.yml configuration file.
    def config(key=nil)
      @config ||= YAML.load_file(Rails.root + "config" + "prismic.yml")
      key ? @config.fetch(key) : @config
    end

    # The access token in configuration.
    def access_token
      config['token']
    end

    ## Easier initialisation of the Prismic::API object.
    def init_api(access_token)
      access_token ||= self.access_token
      Prismic.api(config('url'), access_token)
    end

    def oauth_initiate_url(access_token, oauth_opts)
      access_token ||= self.access_token
      Prismic.oauth_initiate_url(config('url'), oauth_opts, access_token)
    end

    def oauth_check_token(access_token, oauth_opts)
      access_token ||= self.access_token
      Prismic.oauth_check_token(config('url'), oauth_opts, access_token)
    end

    # Gets a document from its ID or DocumentLink
    def get_document(id_or_doclink, api, ref)
      id = id_or_doclink.is_a?(Prismic::Fragments::DocumentLink) ? id_or_doclink.id : id_or_doclink
      documents = api.form("everything")
                     .query("[[:d = at(document.id, \"#{id}\")]]")
                     .submit(ref)

      documents.length == 0 ? nil : documents.first
    end

    # Makes a fragment or the whole document be output in HTML with a lower heading.
    # For instance, "heading1" blocks will serialize in HTML surrounded by <h2> instead of <h1>.
    def lower_html_heading(doc)
      doc.fragments.each { |_, fragment|
        fragment.blocks.each { |block|
          def block.as_html(link_resolver); %(<h#{level+1}>#{text}</h#{level+1}>) end if block.is_a?(Prismic::Fragments::StructuredText::Block::Heading)
        }
      }
    end

    # Checks if the slug is the right one for the document.
    # You can change this depending on your URL strategy.
    def slug_checker(document, slug)
      if document.nil?
        return { correct: false, redirect: false }
      elsif slug == document.slug
        return { correct: true }
      elsif document.slugs.include?(slug)
        return { correct: false, redirect: true }
      else
        return { correct: false, redirect: false }
      end
    end

  end
end
