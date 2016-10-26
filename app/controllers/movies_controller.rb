class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.order(params[:sort])
    @sort_column = params[:sort]
    
    @all_ratings= Movie.all_ratings
    
    unless params[:ratings].nil?
     @filtered_ratings = params[:ratings].keys
     @filtered_ratings = params[:ratings]
     session[:filtered_ratings] = @filtered_ratings
    end

    if params[:sort].nil?
      
    else
      session[:sort] = params[:sort]
    end
    
    if params[:sort].nil? && params[:ratings].nil? && session[:filtered_ratings]
      @filtered_ratings = session[:filtered_ratings]
      @sort = session[:sort]

      flash.keep
      redirect_to movies_path({order_by: @sort, ratings: @filtered_ratings})
    end

    if session[:filtered_ratings]
      @movies = @movies.select{ |movie| session[:filtered_ratings].include? movie.rating }
    end
 
    if params[:sort] == "title"
      @movies = Movie.order("title asc")
    if session[:sort] == "title"
      @movies = @movies.sort { |a,b| a.title <=> b.title }

       @movie_highlight = "hilite"
    elsif params[:sort] == "release_date"
      @movies = Movie.order("release_date asc")
    elsif session[:sort] == "release_date"
      @movies = @movies.sort! { |a,b| a.release_date <=> b.release_date }

       @date_highlight = "hilite"
    else
      @movies = Movie.all
    end
 
    # Deal with movie ratings now...
    @all_ratings = Movie.all_ratings()
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
