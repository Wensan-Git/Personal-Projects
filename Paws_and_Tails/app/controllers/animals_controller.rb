class AnimalsController < ApplicationController
  before_action :set_animal, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  # GET /animals
  def index
    @animals = Animal.all.order(:name)
    @cities = Breeder.get_city_all.sort
    @countries = Breeder.get_country_all.sort
  end

  # GET /animals/1
  def show
    @breeder = Animal.get_breeder(params[:id])
  end

  # GET /animals/new
  def new
    @animal = Animal.new
  end

  # GET /animals/1/edit
  def edit
  end

  # POST /animals
  def create
    @animal = Animal.new(animal_params)

    if @animal.save
      redirect_to @animal, notice: 'Animal was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /animals/1
  def update
    if @animal.update(animal_params)
      redirect_to @animal, notice: 'Animal was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /animals/1
  def destroy
    @animal.destroy
    redirect_to animals_url, notice: 'Animal was successfully destroyed.'
  end

  def sort_location
    city = params[:city] == "Any City" ? nil : params[:city]
    country = params[:country] == "Any Country" ? nil : params[:country]
    sorting_method = params[:sorting]

    animals = Animal.location_refine city, country

    if sorting_method == "Any" || sorting_method == "name"
      animals = animals.order(:name)
    elsif sorting_method != "city" && sorting_method != "country"
      animals = animals.order(sorting_method)
    else
      animals = animals.includes(:breeder).order("breeders.#{sorting_method}")
    end

    breeders = Array.new

    animals.each do |each_animal|
      breeders.push(Animal.get_breeder(each_animal.id))
    end

    respond_to do | format |
      format.json { render json: {animals: animals, breeders: breeders} }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_animal
    @animal = Animal.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def animal_params
    params.require(:animal).permit(:name, :animal_type, :breed, :price, :anticipated_birthday, :breeder_id, :image_link)
  end
end
