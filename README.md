TDL
===========================

Code for the Tufts Digital Library

At the moment if you've set up https://github.com/TuftsUniversity/epigaea appending
run `bundle exec rake hydra:server` from that project, this app will share the
same Solr and Fedora instance.   

## Loading Fixtures
### Notes:
* fixture binaries are located in spec/fixtures
* fixture metadata is located in lib/tufts/populate_fixtures
### Rake Tasks
* rake tufts:fixtures:load_fixtures
* rake tufts:fixtures:delete_fixtures
* rake tufts:fixtures:refresh

### Adding Fixtures to Sipity Workflow

Fixture objects in TDL aren't added to epigea's sipity workflow as that is part of Epigea's local database, the basic code to add an object to the workflow is:
~~~~
object = Rcr.find('rcr00579')
@user = User.find_or_create_by!(email: 'mkorcy@gmail.com')
subject = Hyrax::WorkflowActionInfo.new(object, @user)
Hyrax::Workflow::WorkflowFactory.create(object, {}, @user)
object = object.reload
sipity_workflow_action = PowerConverter.convert_to_sipity_action("publish", scope: subject.entity.workflow) { nil }
Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action , comment: "blah")
~~~~
