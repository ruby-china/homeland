require 'rails_helper'

describe ApplicationRecord, type: :model do
  it 'should have recent scope method' do
    monkey = Monkey.create(name: 'Caesar', id: 1)
    ghost = Monkey.create(name: 'Wukong', id: 2)

    expect(Monkey.recent.to_a).to eq([ghost, monkey])
  end

  it 'should have exclude_ids scope method' do
    ids = Array(1..10)
    ids.each { |i| Monkey.create(name: "entry##{i}", id: i) }

    result1 = Monkey.exclude_ids(ids.to(4).map(&:to_s)).map(&:name)
    result2 = Monkey.exclude_ids(ids.from(5)).map(&:name)

    expect(result1).to eq(ids.from(5).map { |i| "entry##{i}" })
    expect(result2).to eq(ids.to(4).map { |i| "entry##{i}" })
  end

  it 'should have find_by_id class methods' do
    monkey = Monkey.create(name: 'monkey', id: 1)
    expect(Monkey.find_by_id(1)).to eq(monkey)
    expect(Monkey.find_by_id('1')).to eq(monkey)
    expect(Monkey.find_by_id(2)).to be_nil
  end

  it 'should have by_week method' do
    Monkey.create(name: 'Caesar', created_at: 2.weeks.ago.utc)
    Monkey.create(name: 'Caesar1', created_at: 3.days.ago.utc)
    Monkey.create(name: 'Caesar1', created_at: Time.now.utc)
    expect(Monkey.by_week.count).to eq(2)
  end
end
