class FixFacetAudits < ActiveRecord::Migration[6.0]
  SUBSCRIPTION_TERMS = %w(last_checkin service_level release_version autoheal registered_ hypervisor_ hypervisor: purpose_ dmi_uuid)
  CONTENT_TERMS = %w(content_ lifecycle_environment_id kickstart_repository_id installable_ applicable_ upgradable_)
  def up
    broken_audits = Audit.where(auditable_type: 'Host::Base', associated_type: 'Host::Base')

    broken_audits.where(build_like(SUBSCRIPTION_TERMS)).update_all(auditable_type: 'Katello::Host::SubscriptionFacet')
    broken_audits.where(build_like(CONTENT_TERMS)).update_all(auditable_type: 'Katello::Host::ContentFacet')
    # Assuming changes that contain only uuid column are generated by content facet
    broken_audits.where("audited_changes LIKE '%uuid:%'").update_all(auditable_type: 'Katello::Host::ContentFacet')
  end

  # builds a query that looks like
  # audited_changes LIKE '%foo%' or audited_changes LIKE '%bar%' ...
  def build_like(terms)
    terms.map { |term| "audited_changes LIKE '%#{term}%'" }.join(' or ')
  end
end
