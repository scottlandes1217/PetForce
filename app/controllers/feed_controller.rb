class FeedController < ApplicationController
  def index
    @posts = Post.includes(:user, :pet, post_attachments: { file_attachment: :blob })
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(10)

    respond_to do |format|
      format.html # Render the initial HTML view
      format.json do
        render json: {
          posts: @posts.any? ? render_to_string(partial: "posts/post", collection: @posts, as: :post, formats: [:html]) : nil,
          next_page: @posts.next_page
        }
      end
    end
  end
end