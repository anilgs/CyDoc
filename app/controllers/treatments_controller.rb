# -*- encoding : utf-8 -*-
class TreatmentsController < AuthorizedController
  has_scope :by_state

  in_place_edit_for :session, :date
  # TODO: is duplicated in ServiceRecordsController
  in_place_edit_for :service_record, :ref_code
  in_place_edit_for :service_record, :quantity

  # GET /treatments/1
  # GET /patients/1/treatments/2
  def show
    @treatment = Treatment.find(params[:id])

    respond_to do |format|
      format.html { }
      format.js {
        render :update do |page|
          page.replace_html "tab-content-treatments", :partial => 'show'
          page.call 'showTab', controller_name
        end
      }
    end
  end

  def edit
    @treatment = Treatment.find(params[:id])

    respond_to do |format|
      format.html { }
      format.js {
        render :update do |page|
          page.replace_html "treatment", :partial => 'form'
          page.call(:initBehaviour)
        end
      }
    end
  end

  def new
    @treatment = Treatment.new(params[:treatment])
    @treatment.date_begin ||= Date.today

    # Build associated Law object
    @treatment.build_law
  end

  # PUT /patients/1/treatment
  def create
    @patient = Patient.find(params[:patient_id])
    @treatment = @patient.treatments.build(params[:treatment])

    # Law
    law = @treatment.law
    # TODO: don't just pick first one
    insurance_policy = @patient.insurance_policies.by_policy_type(law.name).first
    law.insured_id = insurance_policy.number unless insurance_policy.nil?

    # TODO make selectable
#    @treatment.canton ||= @tiers.provider.vcard.address.region

    # Services
    @treatment.sessions.build(:duration_from => @treatment.date_begin)
#    @treatment.diagnoses = medical_cases.map{|medical_case| medical_case.diagnosis}

    create!
  end

  def destroy
    destroy! { @treatment.patient }
  end

  # Hozr Integration
  def create_all
    @case_count, @failed_cases = Case.create_all_treatments
  end
end
