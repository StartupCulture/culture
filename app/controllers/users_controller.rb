class UsersController < ApplicationController
	before_action :set_core, only: [:show, :edit, :update, :destroy]

	def timeline
		@user = current_user
	end

	def set_core
		@user = User.friendly.find(params[:id])
	end
end
