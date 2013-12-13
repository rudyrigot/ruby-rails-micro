module PrismicHelper

  def url_to_doc(doc, ref)
    document_path(id: doc.id, slug: doc.slug, ref: ref)
  end
  def link_to_doc(doc, ref, html_options={}, &blk)
    link_to(url_to_doc(doc, ref), html_options, &blk)
  end

  def display_doc(doc, ref)
    doc.as_html(link_resolver(ref)).html_safe
  end

  def link_resolver(maybe_ref)
    Prismic::LinkResolver.new(maybe_ref){|doc|
      case doc.link_type
      when 'article'
        case doc.id
        when api.bookmark('homepage')
          root_path(ref: maybe_ref)
        else
          raise "Article of id #{doc.id} doesn't have a known bookmark"
        end
      when 'argument'
        root_path(ref: maybe_ref) + '#' + doc.id
      when 'reference'
        root_path(ref: maybe_ref) + '#' + doc.id
      else
        raise "link_resolver doesn't know how to write URLs for #{doc.link_type} type."
      end
    }
  end

  def privileged_access?
    connected? || PrismicService.access_token
  end

  def connected?
    !!@access_token
  end

  def current_ref
    @ref
  end

  def master_ref
    @api.master_ref.ref
  end

  def api
    @api
  end

end
