module Api
  module V1
    class ConnectionsController < ApplicationController
      before_action :set_self

      # Whole network as nodes + edges so the UI can draw it.
      def network
        edges = Connection.all.map { |c| { from: c.person_id, to: c.other_person_id, strength: c.strength, note: c.note } }
        ids = (edges.flat_map { |e| [e[:from], e[:to]] } + [@self.id]).uniq
        nodes = Person.where(id: ids).map { |p| p.as_json(only: %i[id name kind is_self]) }
        render json: { me: @self.id, nodes: nodes, edges: edges }
      end

      # Shortest introduction path from "me" to the target person.
      def path
        target = Person.find(params.require(:to))
        result = ConnectionPath.new(from: @self, to: target).call
        render json: result || { degrees: nil, path: [], steps: [], notes: [], message: "No path yet. Add someone you know, and Film Mint will look for a route from them." }
      end

      def create
        conn = Connection.create!(person_id: params.require(:person_id), other_person_id: params.require(:other_person_id),
                                  strength: params[:strength] || 3, note: params[:note])
        render json: conn, status: :created
      end

      private

      def set_self
        @self = Person.find_by!(is_self: true)
      end
    end
  end
end
