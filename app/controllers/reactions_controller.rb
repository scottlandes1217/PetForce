class ReactionsController < ApplicationController
    before_action :authenticate_user!
  
    def create
      @reaction = Reaction.find_or_initialize_by(
        user_id: current_user.id,
        post_id: params[:post_id],
        reaction_type: params[:reaction_type]
      )
  
      if @reaction.persisted?
        render json: { message: "You have already reacted with #{params[:reaction_type]}." }, status: :unprocessable_entity
      elsif @reaction.save
        render json: { message: 'Reaction added successfully.', reaction: @reaction }, status: :ok
      else
        render json: { error: 'Failed to add reaction', errors: @reaction.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def destroy
      @reaction = Reaction.find_by(
        user_id: current_user.id,
        post_id: params[:post_id],
        reaction_type: params[:reaction_type]
      )
  
      if @reaction&.destroy
        render json: { message: 'Reaction removed successfully.' }, status: :ok
      else
        render json: { error: 'Failed to remove reaction' }, status: :unprocessable_entity
      end
    end
  end  