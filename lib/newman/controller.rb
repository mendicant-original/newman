module Newman
  class Controller
    def initialize(params)
      self.settings = params.fetch(:settings)
      self.request  = params.fetch(:request)
      self.response = params.fetch(:response)
    end

    attr_accessor :params

    def respond(params)
      params.each { |k,v| response.send("#{k}=", v) }
    end

    def template(name)
      Tilt.new(Dir.glob("#{settings.service.templates_dir}/#{name}.*").first)
          .render(self)
    end

    def sender
      request.from.first.to_s
    end

    def domain
      settings.service.domain 
    end

    def skip_response
      response = nil
    end

    def forward_message(params={})
      response.from      = request.from
      response.reply_to  = settings.service.default_sender 
      response.subject   = request.subject

      params.each do |k,v|
        response.send("#{k}=", v)
      end

      if request.multipart?
        response.text_part = request.text_part
        response.html_part = request.html_part
      else
        response.body = request.body.to_s
      end
    end

    private

    attr_accessor :settings, :request, :response
  end
end
