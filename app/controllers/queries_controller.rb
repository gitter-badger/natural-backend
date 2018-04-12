# Copyright (C) Manuel Arno Korfmann - All Rights Reserved
# Unauthorized copying of this file, or parts of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Manuel Arno Korfmann <manu@korfmann.info>, April 2018

class QueriesController < ApplicationController
  before_action :fetch_database
  before_action :fetch_query, only: [:show, :destroy]

  # GET /queries
  def index
    @database = Database.find(params[:database_id])
    @queries = @database.queries.all

    render json: @queries
  end

  def show
    render json: { result: @query.response_data }
  end

  def create
    @query = @database.queries.build(request_data: params[:sql])
    @query.instant_execution = (params[:instant] == '1')
    Rails.logger.info(Rails.application.config.autoload_paths.inspect)
    puts ::Natural.inspect * 100
    if @query.save
      if @query.instant_execution
        render json: { result: @query.run_query }
      else
        render json: { id: @query.id }, status: :created, location: [@database, @query]
      end
    else
      render json: @query.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @query.destroy
  end

  private

    def fetch_database
      @database = Database.find(params[:database_id])
    end

    def fetch_query
      @query = @database.queries.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def query_params
      params.require(:query).permit(:sql)
    end
end