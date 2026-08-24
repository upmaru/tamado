class Item::PositionsController < ApplicationController
  def update
    project = current_user.projects.find(params[:project_id])
    list = project.lists.find(params[:list_id])

    ids = params.expect(ids: [])
    return head :not_found unless ids.uniq.size == list.items.where(id: ids).count

    Item.transaction do
      ids.each_with_index do |id, index|
        list.items.find(id).update!(position: index + 1)
      end
    end

    head :ok
  end
end
