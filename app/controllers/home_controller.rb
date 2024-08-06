class HomeController < ApplicationController
  # skip authenticity token check
  skip_before_action :verify_authenticity_token
  def index
    # respond with text
    render plain: "Try posting to / with a recipe_url parameter to get a recipe back!"
  end

  def display
    recipe_url_param = params[:recipe_url]

    # decode the url from base 64
    @recipe_url = Base64.decode64(recipe_url_param.to_s)

    # make sure it's a valid url
    if @recipe_url.present? && @recipe_url.match?(URI::DEFAULT_PARSER.make_regexp)
      # get the recipe

      response = RestClient.get(@recipe_url)

      if response.code != 200
        # respond with an error message
        render plain: "Invalid URL", status: :bad_request
      else
        # respond with the recipe
        # render plain: response

        html_body = Nokogiri::HTML(response.body)

        # get this element's data
        # <script type="application/ld+json">

        content = html_body.css('script[type="application/ld+json"]').first.content

        # parse content from json to hash

        seo_data = JSON.parse(content)
        @recipe_data = seo_data['@graph'].find { |data| data['@type'] == 'Recipe' }

        puts JSON.pretty_generate(@recipe_data)
      end
    else
      # respond with an error message
      render plain: "Invalid URL", status: :bad_request
    end
  end
end
