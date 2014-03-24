# encoding: utf-8


class MediaResourceArcsController < ApplicationController

  def index(parent_id = params[:parent_id], child_id = params[:child_id], collection_id = params[:collection_id])
    begin
      arcs = if parent_id
        MediaResourceArc.where(parent_id: parent_id)
      elsif child_id
        MediaResourceArc.where(child_id: child_id)
      elsif collection_id
        MediaResourceArc.where(child_id: MediaResource.by_collection(collection_id))
      end

      render json: {media_resource_arcs: arcs.map{|x| view_context.hash_for_media_resource_arc(x)} }.to_json
    rescue  Exception => e
      binding.pry
      respond_to do |format|
        format.json { render json: e, status: :unprocessable_entity }
      end
    end
  end
  
  def update_arcs(media_resource_arcs = Array(params[:media_resource_arcs].is_a?(Hash) ? params[:media_resource_arcs].values : params[:media_resource_arcs]))
    ActiveRecord::Base.transaction do
      begin 
        media_resource_arcs.each do |arc_params|
          parent = MediaSet.accessible_by_user(current_user, :edit).find(arc_params[:parent_id])
          arc = parent.out_arcs.where(child_id: arc_params[:child_id]).first
          arc.update_attributes!(arc_params)
        end
        respond_to do |format|
          format.json { render json: {} }
        end
      rescue  Exception => e
        respond_to do |format|
          format.json { render json: e, status: :unprocessable_entity }
        end
      end
    end
  end

end


