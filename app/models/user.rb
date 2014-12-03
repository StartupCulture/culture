require 'open-uri'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable,:omniauthable,:omniauth_providers => [:linkedin]

  # FriendlyID Gem
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  def slug_candidates
    [:name,
      [:name, :id]
    ]
  end
  # end

  # PaperClip + Dropbox
  has_attached_file :image,:styles => {
    :large => "512x512" ,
    :medium => "200x200" ,
    :small => "168x168",
    :thumb => "40x40",
    :tiny => "32x32"
    },
    :default_url => :set_default_url,
    :storage => :dropbox,
    :dropbox_credentials => Rails.root.join("config/dropbox.yml"),
    :path =>  "/images/users/:id-:basename.:style.:extension",
    :dropbox_options => {}
    validates_attachment :image,
    :content_type => { :content_type => ["image/jpg", "image/gif", "image/png","image/jpeg",] },
    :size => { :in => 0..6144.kilobytes }

    # if user dont have image
    def set_default_url
      "img/missing.png"
    end
  # End --- 


  # Linkedin oauth
  def skip_confirmation!
    self.confirmed_at = Time.now.utc
  end

  def self.find_for_oauth(auth, signed_in_resource = nil)
      # Get the identity and user if they exist
      identity = Identity.find_for_oauth(auth)
      # If a signed_in_resource is provided it always overrides the existing user
      # to prevent the identity being locked with accidentally created accounts.
      # Note that this may leave zombie accounts (with no associated identity) which
      # can be cleaned up at a later date.
      user = signed_in_resource ? signed_in_resource : identity.user
      # Create the user if needed
      if user.nil?
        # Get the existing user by email if the provider gives us a verified email.
        # If no verified email was provided we assign a temporary email and ask the
        # user to verify it on the next step via UsersController.finish_signup
        email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
        email = auth.info.email
        name = auth.info.name
        headline = auth.info.headline
        location = auth.info.location
        image_linkedin = auth[:extra][:raw_info][:pictureUrls][:values].first
        url_linkedin = auth.info.urls.public_profile

        #Open a new file in referential folder to upload at dropbox
        open(image_linkedin) {|f|
          File.open("public/images/social_user.jpg","wb") do |file|
            file.puts f.read
          end
        }
        # Open local folder/file to save
        image = open('public/images/social_user.jpg')

        # Create the user if it's a new registration
        if user.nil?
        	unless image_linkedin
        		image_linkedin = "http://startupculture.com.br/img/user_missing.png"
        	end
        	user = User.new(
        		name: name,
        		image_linkedin: image_linkedin,
            image:  image,
            headline: headline,
            location: location,
            url_linkedin: url_linkedin,
            email: email,
            password: Devise.friendly_token[0,20]

            )
        	user.skip_confirmation!
        	user.save!
          # Drop created file after save on db/dropbox
          system("cd public/images && rm -rf social_user.jpg")
        end
      end
      # Associate the identity with the user if needed
      if identity.user != user
        identity.user = user
        identity.save!
      end
        user
    end
    def email_verified?
      #self.email && self.email !~ TEMP_EMAIL_REGEX
    end
    # ---- Linkedin Oauth End


    # This trick user dont need repeat current_password to create a new password.
    def update_with_password(params={}) 
    	if params[:password].blank? 
    		params.delete(:password) 
    		params.delete(:password_confirmation) if params[:password_confirmation].blank? 
    	end 
    	update_attributes(params) 
    end

  
end
