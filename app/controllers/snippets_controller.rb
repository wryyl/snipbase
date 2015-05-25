class SnippetsController < ApplicationController

	def new
		if logged_in?
			@snippet = Snippet.new
			render 'add'
		else
			redirect_to login_path
		end
	end
	
	def create
		@snippet = Snippet.new(snippet_params)
		@snippet.user = current_user

		unless @snippet.save
			flash.now[:danger] = @snippet.errors.full_messages[0]
			return fail_to_create
		end

		snippet_file_params_arr.each do |i|
			snippet_file = SnippetFile.new(snippet_file_params_permit(i))
			snippet_file.snippet = @snippet
			set_file_name snippet_file
			unless snippet_file.save
				flash.now[:danger] = snippet_file.errors.full_messages[0]
				return fail_to_create
			end
		end

		p "HSWRSEFSofdf"

        flash[:info] = "Successfully Added!"
        render :js => "window.location = '#{root_path}'" #PLACEHOLDER TO SEE IF CAN ADD.
	end



	private
	def set_file_name snippet_file
		language = snippet_file.language
		language_extension = file_extension language
		filename = snippet_file.filename
		@file_counter ||= {}

		if filename.blank?
			@file_counter[language] ||= 0
			@file_counter[language] += 1
			snippet_file.filename = "SnipFile#{@file_counter[language]}#{language_extension}"
		elsif !filename.end_with? language_extension
			snippet_file.filename = filename+language_extension
		end
	end

	private 
	def file_extension language #Shud have such a method in markup
		".txt"
	end

	private
	def fail_to_create
        @snippet.destroy
        respond_to_update and return
	end

    private
    def respond_to_update
        respond_to do |format|
            format.html { render "add" }
            format.js { render "add" }
        end
    end

	private
    def snippet_params
        params.require(:snippet).permit(:title, :private)
    end

	private
	def snippet_file_params_permit snippet_file_param
		snippet_file_param.permit(:filename, :content, :language)
	end

	private
	def snippet_file_params_arr
		params.require(:snippet_files)
	end
end
