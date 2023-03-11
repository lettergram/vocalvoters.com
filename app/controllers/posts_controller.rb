class PostsController < ApplicationController
  before_action :logged_in_user, except: [:new, :create]
  before_action	:logged_in_admin, only: [:show, :edit, :destroy]
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.order(created_at: :desc).all
               .paginate(page: params[:page]) # Will have to modify
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post,
                                  notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update

    # Change in approval status and not "pending"
    approval_flag = @post.approval_status != post_params['approval_status'] and
      post_params['approval_status'] != 'pending'

    resend_flag = @post.approval_status == "approved" and not post_params[:success]

    respond_to do |format|
      if @post.update(post_params) # approved update
        
        if approval_flag or resend_flag
          if @post.approval_status == "approved"
            
            # clicksend setup authorization             
            ClickSendClient.configure do |config|
              # Configure HTTP basic authorization: BasicAuth
              config.username = ENV["CLICKSEND_USERNAME"]
              config.password = ENV["CLICKSEND_PASSWORD"]
            end

            @post.return_address_id = Post.get_return_address_id(
              @post.sender_name, @post.sender_line_1, @post.sender_line_2,
              @post.sender_city, @post.sender_state, @post.sender_zipcode)

            success = Post.send_post(
              @post.letter_url, @post.recipient.name,
              @post.return_address_id, @post.address_line_1,
              @post.address_line_2, @post.address_city,
              @post.address_state, @post.address_zipcode,
              @post.priority)

            @post.update!(success: success)

            if success # If successsful remove letter_url
              @post.update!(letter_url: nil)
            end
            
            @post.save # commit changes to the db
            
            flash[:success] = 'Successfully Approved Post - Sending!'
            
          elsif @post.approval_status = "declined"
            @post.update!(letter_url: nil) # Remove as decided
            flash[:danger] = 'Declined Sending Post'
          end
        end
        
        format.html {
          redirect_back(fallback_location: @post)
        }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(
        :address_line_1, :address_line_2, :address_city, :address_state,
        :address_zipcode, :approval_status, :success, :sender_id, :recipient_id, :letter_id)
    end
end
