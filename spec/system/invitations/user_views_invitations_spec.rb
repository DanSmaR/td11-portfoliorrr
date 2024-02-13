require 'rails_helper'

describe 'Usuário acessa página de convites' do
  context 'e visualiza seus convites' do
    it 'com sucesso' do
      user = create(:user)
      invitation = create(:invitation, profile: user.profile, expiration_date: Time.zone.now.to_date + 7)
      login_as invitation.profile.user

      visit root_path
      within 'nav' do
        click_button class: 'dropdown-toggle'
        click_on 'Convites'
      end

      expect(current_path).to eq invitations_path
      expect(page).to have_content invitation.project_title
      expect(page).to have_content invitation.truncate_description
      expect(page).to have_content "Expira dia: #{I18n.l(invitation.expiration_date, format: :default)}"
    end

    it 'e nao tem convites' do
      user = create(:user)

      login_as user
      visit invitations_path

      expect(page).to have_content 'Nenhum convite encontrado'
    end

    it 'e visualiza convites expirados' do
      user = create(:user)
      expired_invitation = build(:invitation, profile: user.profile, status: 'expired', expiration_date: 7.days.ago)
      expired_invitation.save(validate: false)
      pending_invitation = create(:invitation, profile: user.profile, project_title: 'Projeto Gotta cath`em all',
                                               project_description: 'Capturar todos os Pokémons',
                                               project_category: 'Collection', colabora_invitation_id: 2)

      login_as user
      visit invitations_path
      click_on 'Expirados'

      expect(page).to have_content expired_invitation.project_title
      expect(page).not_to have_content pending_invitation.project_title
    end

    it 'e visualiza convites pendentes' do
      user = create(:user)
      accepted_invitation = create(:invitation, profile: user.profile, status: 'accepted')
      pending_invitation = create(:invitation, profile: user.profile, project_title: 'Projeto Gotta cath`em all',
                                               project_description: 'Capturar todos os Pokémons',
                                               project_category: 'Collection', colabora_invitation_id: 2)

      login_as user
      visit invitations_path
      click_on 'Pendentes'

      expect(page).not_to have_content accepted_invitation.project_title
      expect(page).not_to have_content accepted_invitation.truncate_description
      expect(page).to have_content pending_invitation.project_title
      expect(page).to have_content pending_invitation.truncate_description
    end

    it 'e visualiza convites aceitos' do
      user = create(:user)
      accepted_invitation = create(:invitation, profile: user.profile, status: 'accepted')
      pending_invitation = create(:invitation, profile: user.profile, project_title: 'Projeto Gotta cath`em all',
                                               project_description: 'Capturar todos os Pokémons',
                                               project_category: 'Collection', colabora_invitation_id: 2)

      login_as user
      visit invitations_path
      click_on 'Aceitos'

      expect(page).to have_content accepted_invitation.project_title
      expect(page).to have_content accepted_invitation.truncate_description
      expect(page).not_to have_content pending_invitation.project_title
      expect(page).not_to have_content pending_invitation.truncate_description
    end

    it 'e visualiza convites rejeitados' do
      user = create(:user)
      declined_invitation = create(:invitation, profile: user.profile, status: 'declined')
      pending_invitation = create(:invitation, profile: user.profile, project_title: 'Projeto Gotta cath`em all',
                                               project_description: 'Capturar todos os Pokémons',
                                               project_category: 'Collection', colabora_invitation_id: 2)

      login_as user
      visit invitations_path
      click_on 'Recusados'

      expect(page).to have_content declined_invitation.project_title
      expect(page).to have_content declined_invitation.truncate_description
      expect(page).not_to have_content pending_invitation.project_title
      expect(page).not_to have_content pending_invitation.truncate_description
    end
  end

  it 'e visualiza convites cancelados' do
    user = create(:user)
    cancelled_invitation = build(:invitation, profile: user.profile, status: 'cancelled')
    cancelled_invitation.save(validate: false)
    pending_invitation = create(:invitation, profile: user.profile, project_title: 'Projeto Gotta cath`em all',
                                             project_description: 'Capturar todos os Pokémons',
                                             project_category: 'Collection', colabora_invitation_id: 2)

    login_as user
    visit invitations_path
    click_on 'Cancelados'

    expect(page).to have_content cancelled_invitation.project_title
    expect(page).not_to have_content pending_invitation.project_title
  end

  it 'e nao visualiza dos outros' do
    user = create(:user)
    other_user = create(:user)
    invitation = create(:invitation, profile: user.profile)
    other_user_invitation = create(:invitation, profile: other_user.profile, project_title: 'Projeto Gotta cath`em all',
                                                project_description: 'Capturar todos os Pokémons',
                                                project_category: 'Collection', colabora_invitation_id: 2)

    login_as user

    visit invitations_path

    expect(page).to have_content invitation.project_title
    expect(page).to have_content invitation.truncate_description
    expect(page).not_to have_content other_user_invitation.project_title
    expect(page).not_to have_content other_user_invitation.truncate_description
  end

  it 'mas precisa estar logado' do
    visit invitations_path

    expect(current_path).to eq new_user_session_path
  end
end
