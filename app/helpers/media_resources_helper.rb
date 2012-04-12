# -*- encoding : utf-8 -*-
module MediaResourcesHelper
  
  def media_resources_index_title

    # TODO
    # _("Suchergebnisse") "für “#{params[:query]}”"
    #_("Keine Einträge gefunden")
    #_("Favoriten")

    case current_settings
      
      when {:type => :all, :permissions => :all}
        _("Alle Inhalte")
      when {:type => :media_entries, :permissions => :all}
        _("Alle Medieneinträge")
      when {:type => :media_sets, :permissions => :all}
        _("Alle Sets")
        
      when {:type => :all, :permissions => :mine}
        _("Meine Inhalte")
      when {:type => :media_entries, :permissions => :mine}
        _("Meine Medieneinträge")
      when {:type => :media_sets, :permissions => :mine}
        _("Meine Sets")
        
      when {:type => :all, :permissions => :entrusted}
        _("Mir anvertraute Inhalte")
      when {:type => :media_entries, :permissions => :entrusted}
        _("Mir anvertraute Medieneinträge")
      when {:type => :media_sets, :permissions => :entrusted}
        _("Mir anvertraute Sets")
        
      when {:type => :all, :permissions => :public}
        _("Öffentliche Inhalte")
      when {:type => :media_entries, :permissions => :public}
        _("Öffentliche Medieneinträge")
      when {:type => :media_sets, :permissions => :public}
        _("Öffentliche Sets")
        
      else
        ""
    end
  end
  
  def current_settings
    h = {}
    
    h[:type] = case params[:type]
      when "media_entries"
        :media_entries
      when "media_sets"
        :media_sets
      else
        :all
    end
    
    h[:permissions] = if (params[:user_id].to_i == current_user.id)
      :mine
    elsif (params[:not_by_current_user] == "true" and params[:public] == "false")
      :entrusted
    elsif (params[:not_by_current_user] == "true" and params[:public] == "true") 
      :public
    else
      :all
    end
    
    h
  end
  
end
