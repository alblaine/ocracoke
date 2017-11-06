module Ocracoke
  class CLI < Thor

    # Adapted from http://stackoverflow.com/a/24829698/620065
    # Add a name for the option that allows for more variability
    class << self
      def add_shared_option(name, options = {})
        @shared_options = {} if @shared_options.nil?
        @shared_options[name] =  options
      end

      def shared_options(*option_names)
        option_names.each do |option_name|
          opt =  @shared_options[option_name]
          raise "Tried to access shared option '#{option_name}' but it was not previously defined" if opt.nil?
          option option_name, opt
        end
      end
    end

    add_shared_option :image, aliases: '-i', type: :string, required: true
    add_shared_option :resource, aliases: '-r', type: :string, required: true

    desc 'ocr', 'run ocr process'
    shared_options :image, :resource
    def ocr
      OcrJob.perform_later options[:image], options[:resource]
    end

    desc 'annotation list job', 'run annotation list process'
    shared_options :image
    def annotate
      AnnotationListJob.perform_later options[:image]
    end

    desc 'concatenate ocr text job', 'run concatenate ocr text process'
    shared_options :image, :resource
    def concatenate_txt
      ConcatenateOcrTxtJob.perform_later options[:image], options[:resource]
    end

    desc 'index ocr job', 'run index process'
    shared_options :image, :resource
    def index
      IndexOcrJob.perform_later options[:image], options[:resource]
    end

    desc 'notification job', 'run notification process'
    shared_options :resource
    def notification
      NotificationJob.perform_later options[:resource]
    end

    desc 'pdf creator job', 'run pdf creator process'
    shared_options :resource
    def pdf
      @images = []
      id = options[:resource]
      @resource = Resource.find_by identifier: id
      unless @resource.images.nil?
        @resource.images.each do |image|
 	  @images.push(image.identifier)
        end
      end 
      puts @images
      PdfCreatorJob.perform_later options[:resource], @images
    end

    desc 'resource ocr job', 'run resource ocr process'
    shared_options :image, :resource
    def resource_ocr
      ResourceOcrJob.perform_later options[:image], options[:resource]
    end

    desc 'word boundaries job', 'run word boundaries process'
    shared_options :image
    def word_boundaries
      WordBoundsJob.perform_later options[:image]
    end 
  end
end
