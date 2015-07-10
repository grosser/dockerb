require 'erb'
require 'dockerb/version'

module Dockerb
  GENERATED = "# Generated by dockerb VERSION, do not modify"
  SEARCH = /#{Regexp.escape(GENERATED).sub('VERSION', '([\d\.]+)')}/

  class << self
    def compile(&block)
      return (yield if block) unless File.exist?("Dockerfile.erb")
      ensure_not_older_than_last
      compile_dockerfile(&block)
    end

    private

    def ensure_not_older_than_last
      return unless File.exist?("Dockerfile")
      return unless old = File.read("Dockerfile")[SEARCH, 1]
      return unless Gem::Version.new(old) > Gem::Version.new(VERSION)
      raise "Previous file was generated by dockerb #{old}, use it or a newer version."
    end

    def compile_dockerfile(&block)
      File.write("Dockerfile", Context.compile(File.read("Dockerfile.erb")))
      yield if block
    ensure
      File.unlink("Dockerfile") if File.exist?("Dockerfile") && block
    end
  end

  class Context
    class << self
      def compile(code)
        warn = "#{GENERATED.sub('VERSION', Dockerb::VERSION)}\n"
        warn + ERB.new(code).result(binding).strip + "\n" + warn
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
        %{find #{gem_home}/*/ext/ -maxdepth 1 -mindepth 1 -type d | xargs -L1 bash -c 'if [ -e $0/Makefile ]; then make -C $0 clean; fi'}
      end

      def gem_home
        "/usr/local/lib/ruby/gems/*/gems"
      end
    end
  end
end
