module Locomotive::Builder
  class Server

    # Sanitize the path from the previous middleware in order
    # to make it work for the renderer.
    #
    class Page < Middleware

      def call(env)
        self.set_accessors(env)

        self.set_page!(env)

        app.call(env)
      end

      protected

      def set_page!(env)
        path = env['builder.path']

        page = self.fetch_page(path)

        puts "[Builder|Page] #{page.inspect}"

        env['builder.page'] = page
      end

      def fetch_page(path)
        matchers = self.path_combinations(path)

        self.mounting_point.pages.values.detect do |_page|
          matchers.include?(_page.safe_fullpath) ||
          matchers.include?(_page.safe_fullpath.underscore)
        end
      end

      def path_combinations(path)
        self._path_combinations(path.split('/'))
      end

      def _path_combinations(segments, can_include_template = true)
        return nil if segments.empty?

        segment = segments.shift

        (can_include_template ? [segment, '*'] : [segment]).map do |_segment|
          if (_combinations = _path_combinations(segments.clone, can_include_template && _segment != '*'))
            [*_combinations].map do |_combination|
              File.join(_segment, _combination)
            end
          else
            [_segment]
          end
        end.flatten
      end

    end

  end
end