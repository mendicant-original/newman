module PostalService
  class Controller
    def initialize(params)
      self.config   = params.fetch(:config)
      self.request  = params.fetch(:request)
      self.response = params.fetch(:response)
    end

    attr_accessor :params

    def respond(params)
      params.each { |k,v| response.send("#{k}=", v) }
    end

    def template(name)
      Tilt.new(Dir.glob("#{config[:templates_dir]}/#{name}.*").first)
          .render(self)
    end

    def sender
      request.from.first.to_s
    end

    def domain
      config[:domain]
    end

    def forward_message(params={})
      response.from      = request.from
      response.reply_to  = config[:default_address]
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

    attr_accessor :config, :request, :response
  end
end
