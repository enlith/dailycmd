



# Build static rust app binary for old android TVBox



Take rust project merino for example.

https://github.com/ajmwagar/merino



Install rust environment 

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh



Clone rust app project 

git clone https://github.com/ajmwagar/merino

Add rust target arch 

```bash
rustup target add armv7-unknown-linux-musleabihf

cargo build --release --target armv7-unknown-linux-musleabihf
```

Add extra cargo config, if probably found link error 

```bash
cat > ~/.cargo/config.toml << EOF

[target.armv7-unknown-linux-musleabihf]
linker = "rust-lld"

EOF
```



build again

```bash
cargo build --release --target armv7-unknown-linux-musleabihf
```



The output binary can be found at 

```bash
file ./target/armv7-unknown-linux-musleabihf/release/merino
./target/armv7-unknown-linux-musleabihf/release/merino: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, with debug_info, not stripped
```

Upload and start service

```bash
./merino --no-auth --ip=0.0.0.0 --port=9080
```

Use "SOCKS5 <yourip>:9080" in your proxy setting. Currently there is one issue regarding DNS resolving. Proxy to http://<ipaddress> is working , proxy to https://<hostname> failed due to the error. 

probably need to modify tokio::net:lookup_host in src file src/lib.rs

```rust
use tokio::net::{TcpListener, TcpStream, lookup_host};
...
/// Convert an address and AddrType to a SocketAddr
async fn addr_to_socket(addr_type: &AddrType, addr: &[u8], port: u16) -> io::Result<Vec<SocketAddr>> {
    match addr_type {
        AddrType::V6 => {
            let new_addr = (0..8)
                .map(|x| {
                    trace!("{} and {}", x * 2, (x * 2) + 1);
                    (u16::from(addr[(x * 2)]) << 8) | u16::from(addr[(x * 2) + 1])
                })
                .collect::<Vec<u16>>();

            Ok(vec![SocketAddr::from(SocketAddrV6::new(
                Ipv6Addr::new(
                    new_addr[0],
                    new_addr[1],
                    new_addr[2],
                    new_addr[3],
                    new_addr[4],
                    new_addr[5],
                    new_addr[6],
                    new_addr[7],
                ),
                port,
                0,
                0,
            ))])
        }
        AddrType::V4 => Ok(vec![SocketAddr::from(SocketAddrV4::new(
            Ipv4Addr::new(addr[0], addr[1], addr[2], addr[3]),
            port,
        ))]),
        AddrType::Domain => {
            let mut domain = String::from_utf8_lossy(addr).to_string();
            domain.push(':');
            domain.push_str(&port.to_string());

            Ok(lookup_host(domain).await?.collect())
        }
    }
}
```



few more possible commands

```bash
sudo dpkg --add-architecture armhf
sudo apt-get update
sudo apt-get install -y curl git build-essential
sudo apt-get install -y libc6-armhf-cross libc6-dev-armhf-cross gcc-arm-linux-gnueabihf
sudo apt-get install -y libdbus-1-dev libdbus-1-dev:armhf
```



References:

[Merino project]: https://github.com/ajmwagar/merino
[build-armv7]: https://users.rust-lang.org/t/how-to-install-armv7-unknown-linux-musleabihf/82395



