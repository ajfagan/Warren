use clap::{Parser, Subcommand, Args};

pub use crate::devices::devices::{WarrenDevice, DeviceKind};

pub fn parse_cli() -> std::io::Result<()> {
    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Init(device)) => {
            device.kind.init()
        },
        Some(Commands::Run(device)) => {
            device.kind.run()
        },
        None => {
            DeviceKind::Server.run()
        },
    }
}

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
pub struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}
impl DeviceKind {
    fn run(&self) -> std::io::Result<()> {
        match self {
            DeviceKind::Server => {
                if let Ok(true) = std::path::Path::new(".warren/conf.yaml").try_exists() {
                    crate::boot_server()
                } else {
                    Err(std::io::Error::other("Database directory not found"))
                }
            }
        }
    }
    fn init(&self) -> std::io::Result<()> {
        match self {
            DeviceKind::Server => {
                if let Ok(true) = std::path::Path::new(".warren/").try_exists() {
                   Err(std::io::Error::other("A database already exists")) 
                } else {
                    std::fs::create_dir(std::path::Path::new(".warren/"))
                }
            }
        }
    }
}

#[derive(Subcommand, Debug)]
enum Commands {
    Init(WarrenDevice),
    Run(WarrenDevice),
}

