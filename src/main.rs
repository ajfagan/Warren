#[macro_use]
extern crate diesel;
pub mod schema;
pub mod models;

pub mod devices;

pub mod cli_parser;

use diesel::prelude::*;
use diesel::pg::PgConnection;
use dotenvy::dotenv;

use models::{User, NewUser, LoginUser};

use actix_web::{HttpServer, App, web, HttpResponse, Responder};
use tera::{Tera, Context};
use serde::{Serialize, Deserialize};
use actix_identity::{Identity, CookieIdentityPolicy, IdentityService};

pub trait WarrenRunner {
    fn init(&self) -> std::io::Result<()>;
    fn run(&self) -> std::io::Result<()>;
}

async fn login(tera: web::Data<Tera>, id: Identity) -> impl Responder {
    let mut data = Context::new();
    data.insert("title", "Login");

    if let Some(id) = id.identity() {
        return HttpResponse::Ok().body("Already logged in.")
    }

    let rendered = tera.render("login.html", &data).unwrap();
    HttpResponse::Ok().body(rendered)
}
async fn process_login(data: web::Form<LoginUser>, id: Identity) -> impl Responder {
    use schema::users::dsl::{username, users};

    let mut connection = establish_connection();
    let user = users.filter(username.eq(&data.username)).first::<User>(&mut connection);

    match user {
        Ok(u) => {
            if u.password == data.password {
                let session_token = String::from(u.username);
                id.remember(session_token);
                HttpResponse::Ok().body(format!("Logged in: {}", data.username))
            } else {
                HttpResponse::Ok().body("Password is incorrect.")
            }
        },
        Err(e) => {
            println!("{:?}", e);
            HttpResponse::Ok().body("User doesn't exist.")
        },
    }
}

async fn logout(id: Identity) -> impl Responder {
    id.forget();
    HttpResponse::Ok().body("Logged out.")
}

fn establish_connection() -> PgConnection{
    dotenv().ok();

    let database_url = std::env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set");

    PgConnection::establish(&database_url)
        .expect(&format!("Error connection to {}", database_url))
}

async fn process_signup(data: web::Form<NewUser>) -> impl Responder {
    use schema::users;

    let mut connection = establish_connection();

    diesel::insert_into(users::table)
        .values(&*data) 
        .get_result::<User>(&mut connection)
        .expect("Error registering user.");

    println!("{:?}", data);

    HttpResponse::Ok().body(format!("Successfully saved user: {}", data.username))
}

fn main() -> std::io::Result<()> {
    cli_parser::parse_cli()
}

#[actix_web::main]
async fn boot_server() -> std::io::Result<()> {
    HttpServer::new( || {
        let tera = Tera::new("templates/**/*.html").unwrap();
        App::new()
            .wrap(IdentityService::new(
                    CookieIdentityPolicy::new(&[0;32])
                        .name("auth-cookie")
                        .secure(false)
            ))
            .data(tera)
            .route("/", web::get().to(index))
            .route("/signup", web::get().to(signup))
            .route("/signup", web::post().to(process_signup))
            .route("/login", web::get().to(login))
            .route("/login", web::post().to(process_login))
            .route("/logout", web::to(logout))
            .service(actix_files::Files::new("/styles", "./templates/styles").show_files_listing())
            .service(actix_files::Files::new("/images", "./templates/images").show_files_listing())
    })
    .bind("127.0.0.1:8000")?
    .run()
    .await
} 

async fn index(tera: web::Data<Tera>) -> impl Responder {
    let mut data = Context::new();
    data.insert("title", "Warren");
    data.insert("name", "Buddy the Friend Pal");

    let rendered = tera.render("index.html", &data).unwrap();
    HttpResponse::Ok().body(rendered)
}

async fn signup(tera: web::Data<Tera>) -> impl Responder {
    let mut data = Context::new();
    data.insert("title", "Sign up");

    let rendered = tera.render("signup.html", &data).unwrap();
    HttpResponse::Ok().body(rendered)
}
