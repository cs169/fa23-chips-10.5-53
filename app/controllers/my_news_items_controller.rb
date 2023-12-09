# frozen_string_literal: true
require 'net/http'
require 'uri'
require 'json'

class MyNewsItemsController < SessionController
  before_action :set_representative
  before_action :set_representatives_list
  before_action :set_news_item, only: %i[edit update destroy]

  def new
    @news_item = NewsItem.new
  end

  def step1
    @news_item = NewsItem.new
  end

  def step2
    @representative = Representative.find(params[:news_item][:representative_id])
    @issue = params[:news_item][:issue]
    @articles = fetch_articles(@representative, @issue)
  end

  def save_article
    selected_index = params[:news_item][:selected_article].to_i
    selected_article = params[:news_item][:articles][selected_index.to_s]
  
    @news_item = NewsItem.new(
      title: selected_article[:title],
      description: selected_article[:description],
      link: selected_article[:link],
      representative_id: params[:news_item][:representative_id],
      issue: params[:news_item][:issue],
      rating: params[:news_item][:rating]
    )

    if @news_item.save
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully created.'
    else
      render :new, error: 'An error occurred when creating the news item.'
    end
  end

  def edit; end

  def create
    @news_item = NewsItem.new(news_item_params)
    if @news_item.save
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully created.'
    else
      render :new, error: 'An error occurred when creating the news item.'
    end
  end

  def update
    if @news_item.update(news_item_params)
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully updated.'
    else
      render :edit, error: 'An error occurred when updating the news item.'
    end
  end

  def destroy
    @news_item.destroy
    redirect_to representative_news_items_path(@representative),
                notice: 'News was successfully destroyed.'
  end

  private

  def fetch_articles(representative, issue)
    uri = URI('https://newsapi.org/v2/everything')
    params = { 
      'q' => "#{representative.name} #{issue}",
      'apiKey' => Rails.application.credentials.NEWS_API_KEY
    }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      result = JSON.parse(response.body)
      
      # Extract articles from response
      articles = result['articles']
  
      # Extract top 5 articles and their information
      top_articles = articles.take(5).map do |article|
        {
          title: article['title'],
          url: article['url'],
          description: article['description']
        }
      end
      # Display or handle the top articles
      top_articles
    else
      puts "Error: #{response.code}"
    end
  end

  def set_representative
    @representative = Representative.find(
      params[:representative_id]
    )
  end

  def set_representatives_list
    @representatives_list = Representative.all.map { |r| [r.name, r.id] }
  end

  def set_news_item
    @news_item = NewsItem.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def news_item_params
    params.require(:news_item).permit(:news, :title, :description, :link, :representative_id, :issue, :rating)
  end
end
