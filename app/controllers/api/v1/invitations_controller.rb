module Api
  module V1
    class InvitationsController < ApiController
      def create
        invitation = Invitation.create!(invite_params)
        InvitationsMailer.with(invitation).received_invitation.deliver_later
        render status: :created, json: { data: { invitation_id: invitation.id } }
      end

      def update
        status = params.permit(:status)[:status]
        unless Invitation.statuses.key? status
          return render status: :bad_request,
                        json: { error: I18n.t('invalid_status') }
        end

        invitation = Invitation.find(params[:id])
        invitation.update!(status:)
      end

      private

      def invite_params
        invitation_params = :profile_id, :project_id, :project_title,
                            :project_description, :project_category,
                            :colabora_invitation_id, :message,
                            :expiration_date
        params.require(:invitation).permit(invitation_params)
      end
    end
  end
end
