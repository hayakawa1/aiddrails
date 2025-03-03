# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_03_123653) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "company_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "company_name"
    t.text "description"
    t.string "website_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_company_profiles_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "target_user_id", null: false
    t.bigint "job_id", null: false
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_conversations_on_job_id"
    t.index ["target_user_id"], name: "index_conversations_on_target_user_id"
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "employment_types", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "individual_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "display_name"
    t.integer "birth_year"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "desired_salary"
    t.index ["user_id"], name: "index_individual_profiles_on_user_id"
  end

  create_table "job_skills", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "skill_id", null: false
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_job_skills_on_job_id"
    t.index ["skill_id"], name: "index_job_skills_on_skill_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "company_profile_id", null: false
    t.bigint "employment_type_id", null: false
    t.bigint "work_style_id", null: false
    t.bigint "location_id", null: false
    t.integer "salary_min"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "legal_info"
    t.index ["company_profile_id"], name: "index_jobs_on_company_profile_id"
    t.index ["employment_type_id"], name: "index_jobs_on_employment_type_id"
    t.index ["location_id"], name: "index_jobs_on_location_id"
    t.index ["work_style_id"], name: "index_jobs_on_work_style_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "job_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "target_user_id"
    t.index ["job_id"], name: "index_likes_on_job_id"
    t.index ["target_user_id"], name: "index_likes_on_target_user_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.integer "sender_id", null: false
    t.text "content"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_employment_types", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "employment_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employment_type_id"], name: "index_user_employment_types_on_employment_type_id"
    t.index ["user_id"], name: "index_user_employment_types_on_user_id"
  end

  create_table "user_locations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_user_locations_on_location_id"
    t.index ["user_id"], name: "index_user_locations_on_user_id"
  end

  create_table "user_skills", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "skill_id", null: false
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["skill_id"], name: "index_user_skills_on_skill_id"
    t.index ["user_id"], name: "index_user_skills_on_user_id"
  end

  create_table "user_work_styles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "work_style_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_work_styles_on_user_id"
    t.index ["work_style_id"], name: "index_user_work_styles_on_work_style_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_id"
    t.string "password"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "work_styles", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "company_profiles", "users"
  add_foreign_key "conversations", "jobs"
  add_foreign_key "conversations", "users"
  add_foreign_key "conversations", "users", column: "target_user_id"
  add_foreign_key "individual_profiles", "users"
  add_foreign_key "job_skills", "jobs"
  add_foreign_key "job_skills", "skills"
  add_foreign_key "jobs", "company_profiles"
  add_foreign_key "jobs", "employment_types"
  add_foreign_key "jobs", "locations"
  add_foreign_key "jobs", "work_styles"
  add_foreign_key "likes", "jobs"
  add_foreign_key "likes", "users"
  add_foreign_key "likes", "users", column: "target_user_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "user_employment_types", "employment_types"
  add_foreign_key "user_employment_types", "users"
  add_foreign_key "user_locations", "locations"
  add_foreign_key "user_locations", "users"
  add_foreign_key "user_skills", "skills"
  add_foreign_key "user_skills", "users"
  add_foreign_key "user_work_styles", "users"
  add_foreign_key "user_work_styles", "work_styles"
end
