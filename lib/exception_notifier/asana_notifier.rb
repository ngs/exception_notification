class ExceptionNotifier
  class AsanaNotifier
    cattr_accessor :asana_available do true end

    attr_accessor :workspace_id
    attr_accessor :api_key

    def initialize(options)
      begin
        return unless asana_available

        workspace_id = options.delete(:workspace_id)
        api_key      = options.delete(:api_key)

        Asana.configure do |client|
          client.api_key = api_key
        end
        @workspace = Asana::Workspace.find(workspace_id)
      rescue
        @workspace = nil
      end
    end

    def exception_notification(exception)
      if active?
        @workspace.create_task({
          :name => "[Exception] #{exception.message}",
          :note => exception.backtrace.first
        })
      end
    end

    private

    def active?
      !@workspace.nil?
    end
  end
end

ExceptionNotifier::AsanaNotifier.asaan_available = Gem.loaded_specs.keys.include? 'asana'
