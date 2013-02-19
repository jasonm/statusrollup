require 'spec_helper'

feature 'Rolling up commit statuses for a SHA' do
  scenario 'view aggregate status' do
    # [46] pry(main)> #ss = g.repos.statuses.list('clahub','clahub-org-test',m.sha);nil
    sss = [{
      "url"=> "https://api.github.com/repos/clahub/clahub-org-test/statuses/f2ae99f44eac071edb46bbea3e4c4e16c8cff2d7",
      "id"=>5013270,
      "state"=>"success",
      "description"=> "All contributors have signed the Contributor License Agreement.",
      "target_url"=>"http://www.clahub.com/agreements/clahub/clahub-org-test",
      "creator"=> {"login"=>"jasonm",...  "type"=>"User"},
      "created_at"=>"2013-02-19T04:34:02Z",
      "updated_at"=>"2013-02-19T04:34:02Z"
    }, {
      "url"=> "https://api.github.com/repos/clahub/clahub-org-test/statuses/f2ae99f44eac071edb46bbea3e4c4e16c8cff2d7",
      "id"=>5013258,
      "state"=>"success",
      "description"=> "All contributors have signed the Contributor License Agreement.",
      "target_url"=>"http://www.clahub.com/agreements/clahub/clahub-org-test",
      "creator"=> {"login"=>"jasonm",...  "type"=>"User"},
      "created_at"=>"2013-02-19T04:33:43Z",
      "updated_at"=>"2013-02-19T04:33:43Z"
    }]
  end

  scenario 'view per-service status with details'
  scenario 'view historical status with details'
  scenario 'set aggregate status on the commit'
end
