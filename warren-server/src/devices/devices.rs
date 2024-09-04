use clap::{Parser, Subcommand, Args};
#[derive(Args, Debug )]
pub struct WarrenDevice { 
    #[clap(value_enum, default_value_t = DeviceKind::Server)]
    pub kind: DeviceKind 
}
#[derive( Debug, Default, Clone, clap::ValueEnum, )]
pub enum DeviceKind {
    #[default]
    Server,
}
