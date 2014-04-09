require('cgi')

module Prismic

	class Document
		# Simply to avoid typing .html_safe at the end of each as_html call.
		def as_html_safe(link_resolver = nil)
			as_html(link_resolver).html_safe
		end
	end

	module Fragments
		class Fragment

			# Simply to avoid typing .html_safe at the end of each as_html call.
			def as_html_safe(link_resolver = nil)
				as_html(link_resolver).html_safe
			end
		end

		class StructuredText
			class Block
				class Preformatted
					def as_html(link_resolver=nil)
			            %(<pre>#{CGI.escapeHTML(super)}</pre>)
			          end
				end
			end
		end

		class StructuredText
			class Block
				class Image
					def as_html(link_resolver = nil)
						%(<p class="image"><img src="#{url}"></p>)
					end
				end
			end
		end

	end
end
