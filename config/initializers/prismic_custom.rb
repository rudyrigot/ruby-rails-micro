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

		class Group

			def each(&blk)
				@fragment_list_array.each { |elem| yield(elem) }
			end
			def map(&blk)
				@fragment_list_array.map { |elem| yield(elem) }
			end
			def length
				@fragment_list_array.length
			end
			def empty?
				@fragment_list_array.empty?
			end
		end

		# You can override any of the kit's features at will, in its HTML serialization for instance.
		# (The kit provides a basic one, but you get to make the one that best fits your design)
		# For instance, below is a commented-out overriding of the HTML serialization for images within StructuredText fragments.
=begin
		class StructuredText
			class Block
				class Image
					def as_html(link_resolver = nil)
						%(<p class="image"><img src="#{url}"></p>)
					end
				end
			end
		end
=end

	end
end