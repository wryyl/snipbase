class AdminsController < ApplicationController  
    before_filter  :ensure_authenticated_admin, :except => [:toggle_admin]

    def show
        @admins = User.where(:is_admin => true)
    end

    def admin_search
        users = User.select("username, name").where("lower(username) LIKE ?", "%#{params[:query].downcase}%").where(:is_admin => false)
        render json: users.to_json
    end

    def ensure_authenticated_admin
        if (!current_user.is_admin)
            redirect_to root_path
            return
        end
    end

    def add_admin
        @admins = User.where(:is_admin => true)
        admins_to_process = params[:admins].split(",")
        respond_to_request and return if admins_to_process.empty?
        success = true

        admins_to_process.each do |a|
            admin = User.find_by(:username => a)
            if !toggle_admin?(admin)
                msg = "An UNEXPECTED Error has occurred for user #{a}"
                flash[:danger] = msg
                success = false
            end
        end

        flash[:success] = "You have new admin(s)! => #{params[:admins]}" if success

        respond_to_request
    end

    def delete_admin
        @admins = User.where(:is_admin => true)
        user = User.find(params[:id])
        if (user == User.find_by(:username => 'admin'))
            msg = "Cannot Remove Default Admin"
            flash.now[:danger] = msg
        elsif toggle_admin?(user)
            msg = "Successfully removed #{user.username}"
            flash.now[:success] = msg
        else
            msg = "An UNEXPECTED Error has occurred"
            flash.now[:danger] = msg
        end
        respond_to_request
    end

    def toggle_admin? user
        if (user.is_admin)
            user.is_admin = false
        else
            user.is_admin = true
        end

        return true if user.save
        false
    end

    def respond_to_request
        respond_to do |format|
            format.html { redirect_to admin_path }
            format.js { render 'toggle_admin'}
        end
    end
end
