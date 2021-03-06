class PeopleController < ApplicationController

  def index
    raise NotPermitted unless current_person.is_superadmin?
    @people = Person.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @people }
    end
  end

  def show
    @person = Person.find(params[:id])
    raise NotPermitted unless @person.viewable_by?(current_person)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person }
    end
  end

  def edit
    @person = Person.find(params[:id])
    raise NotPermitted unless @person.editable_by?(current_person)
  end

  def generate_email_key
    @person = Person.find(params[:id])
    raise NotPermitted unless @person.editable_by?(current_person)
    @person.generate_email_key

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @person, notice: 'Secret email was successfully updated.' }
      else
        format.html { redirect_to @person, alert: 'Sorry, something went wrong.' }
      end
    end
  end

  def update
    @person = Person.find(params[:id])
    raise NotPermitted unless @person.editable_by?(current_person)

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @person = Person.find(params[:id])
    raise NotPermitted unless @person == current_person or current_person.is_superadmin?
    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end


end
