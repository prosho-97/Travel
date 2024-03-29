class ReviewsController < ApplicationController

    before_action :authenticate_user!

    def new
        # default: render ’new’ template
    end

    def create
        id_place = params[:place_id]
		@place = Place.find(id_place)
        @user = current_user
        pre_average = @place.average
        @review = @place.reviews.build(params[:review].permit(:rating, :comments))
        authorize! :create, @review, :message => "BEWARE: You are not authorized to create a new review."
        @user.reviews << @review
        @review.save!
        @place.average = ((pre_average * (@place.reviews.count - 1)) + @review.rating) / @place.reviews.count
        @place.save!
        respond_to do |client_wants|
            client_wants.html {
                flash[:notice] = "A review has from #{@user.email} been successfully added to #{@place.name}."
                redirect_to place_path(@place)
            }
            client_wants.xml { render :xml => @review.to_xml }
        end
    end

    
    def edit
        @review = Review.find params[:id]
        authorize! :update, @review, :message => "BEWARE: You are not authorized to edit a review."
        flash[:previous_page] = request.referer
    end

    def update
        @review = Review.find params[:id]
        authorize! :update, @review, :message => "BEWARE: You are not authorized to update a review."
        @place = @review.place
        @place.average = @place.average * @place.reviews.count - @review.rating
        @review.update_attributes!(params[:review].permit(:rating, :comments))
        @place.average = (@place.average + @review.rating) / @place.reviews.count
        @place.save!
        respond_to do |client_wants|
            client_wants.html {
                flash[:notice] = "Review was successfully added."
                redirect_to flash[:previous_page]
            }
            client_wants.xml { render :xml => @review.to_xml }
        end
    end

    def destroy
        id = params[:id]
        @review = Review.find(id)
        if(current_user == @review.user || current_user.is?(:moderator) || current_user.is?(:admin))
            id_place = params[:place_id]
            @place = Place.find(id_place)
            authorize! :destroy, @review, :message => "BEWARE: You are not authorized to delete a review."
            if @place.reviews.count == 1
                @place.average = 0
            else
                @place.average = (@place.average * @place.reviews.count - @review.rating) / (@place.reviews.count - 1)
            end
            @place.save!
            @review.destroy
            flash[:notice] = "The review of #{@review.user.email} has been deleted."
        else
            flash[:warning] = "You cannot delete the review of another user"
        end
        redirect_to request.referer
    end

end
