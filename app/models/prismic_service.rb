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

    # Gets a document from its ID.
    def get_document(id, api, ref)
      documents = api.create_search_form("everything")
                     .query("[[:d = at(document.id, \"#{id}\")]]")
                     .submit(ref)

      documents.empty? ? nil : documents.first
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
