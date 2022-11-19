class BreedersController < ApplicationController
  before_action :set_breeder, only: [:show, :edit, :update, :destroy]

  # GET /breeders
  def index
    @breeders = Breeder.all
  end

  # GET /breeders/1
  def show
    breeder_id = params[:id]
    @animals = Breeder.get_animals(breeder_id)
  end

  # GET /breeders/new
  def new
    @breeder = Breeder.new
  end

  # GET /breeders/1/edit
  def edit
  end

  # POST /breeders
  def create
    @breeder = Breeder.new(breeder_params)

    if @breeder.save
      redirect_to @breeder, notice: 'Breeder was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /breeders/1
  def update
    if @breeder.update(breeder_params)
      redirect_to @breeder, notice: 'Breeder was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /breeders/1
  def destroy
    @breeder.destroy
    redirect_to breeders_url, notice: 'Breeder was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_breeder
    @breeder = Breeder.find(params[:id])
  end



  # Only allow a trusted parameter "white list" through.
  def breeder_params
    params.require(:breeder).permit(:name, :city, :country, :price_level, :address, :email)
  end
end
