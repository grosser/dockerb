require 'erb'

module Dockerb
  class << self
    def compile
      return (yield if block_given?) unless File.exist?("Dockerfile.erb")
      begin
        File.write("Dockerfile", Context.compile(File.read("Dockerfile.erb")))
        yield if block_given?
      ensure
        File.unlink("Dockerfile") if File.exist?("Dockerfile") && block_given?
      end
    end
  end

  class Context
    class << self
      def compile(code)
        ERB.new(code).result(binding)
      end

      def bundle
        <<-EOF.gsub(/^          /, "")
          ADD Gemfile /app/
          ADD Gemfile.lock /app/
          ADD vendor/cache /app/vendor/cache
          RUN (bundle install --quiet --local --jobs 4 || bundle check) && #{delete_gem_junk}
        EOF
      end

      def install_gem(name, options=nil)
        options = " " << options if options
        version = File.read("Gemfile.lock")[/^    #{name} \((.+)\)/, 1] || raise("Gem #{name} not found in Gemfile.lock")
        "RUN gem install -v #{version} #{name}#{options} && #{delete_gem_junk}"
      end

      def delete_gem_junk
        "#{delete_tests} && #{delete_build_files}"
      end

      private

      def delete_tests
        %{find #{gem_home}/ -maxdepth 2 -name "test" -o -name "spec" | xargs rm -r}
      end

      # deleting all of ext makes nokogiri + Nokogumbo install fail
      def delete_build_files
        %{find #{gem_home}/*/ext/ -maxdepth 1 -mindepth 1 -type d | xargs -I% make -C % clean}
      end

      def gem_home
        "/usr/local/lib/ruby/gems/*/gems"
      end
    end
  end
end
