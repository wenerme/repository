# brew install --build-from-source wenerme/repository/tinc-pre
class TincPre < Formula
  desc "Virtual Private Network (VPN) tool"
  homepage "https://www.tinc-vpn.org/"
  url "https://www.tinc-vpn.org/packages/tinc-1.1pre18.tar.gz"
  sha256 "2757ddc62cf64b411f569db2fa85c25ec846c0db110023f6befb33691f078986"

  depends_on "lzo"
  depends_on "openssl"

  # ConnectTo connection protection with dynamic threshold
  # ConnectTo connection protection with dynamic threshold
  # macOS ifreq compatibility fix
  patch :DATA

  def install
    ENV.append "CFLAGS", "-Wno-incompatible-function-pointer-types"
    system "./configure", "--prefix=#{prefix}", "--sysconfdir=#{etc}",
                          "--with-openssl=#{Formula["openssl"].opt_prefix}"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{sbin}/tincd --version")
  end
end

__END__
diff --git a/src/autoconnect.c b/src/autoconnect.c
index d25d65e..969b049 100644
--- a/src/autoconnect.c
+++ b/src/autoconnect.c
@@ -114,7 +114,8 @@ static void drop_superfluous_outgoing_connection() {
 	int count = 0;
 
 	for list_each(connection_t, c, connection_list) {
-		if(!c->edge || !c->outgoing || !c->node || c->node->edge_tree->count < 2) {
+		if(!c->edge || !c->outgoing || !c->node || c->node->edge_tree->count < 2
+		   || c->outgoing->from_connectto) {
 			continue;
 		}
 
@@ -128,7 +129,8 @@ static void drop_superfluous_outgoing_connection() {
 	int r = rand() % count;
 
 	for list_each(connection_t, c, connection_list) {
-		if(!c->edge || !c->outgoing || !c->node || c->node->edge_tree->count < 2) {
+		if(!c->edge || !c->outgoing || !c->node || c->node->edge_tree->count < 2
+		   || c->outgoing->from_connectto) {
 			continue;
 		}
 
@@ -166,23 +168,28 @@ static void drop_superfluous_pending_connections() {
 }
 
 void do_autoconnect() {
-	/* Count number of active connections. */
+	/* Count number of active connections and ConnectTo connections. */
 	int nc = 0;
+	int connectto_count = 0;
 
 	for list_each(connection_t, c, connection_list) {
 		if(c->edge) {
 			nc++;
+			if(c->outgoing && c->outgoing->from_connectto)
+				connectto_count++;
 		}
 	}
 
-	/* Less than 3 connections? Eagerly try to make a new one. */
-	if(nc < 3) {
+	int min_connections = connectto_count > 3 ? connectto_count : 3;
+
+	/* Less than min_connections? Eagerly try to make a new one. */
+	if(nc < min_connections) {
 		make_new_connection();
 		return;
 	}
 
-	/* More than 3 connections? See if we can get rid of a superfluous one. */
-	if(nc > 3) {
+	/* More than min_connections? See if we can get rid of a superfluous one. */
+	if(nc > min_connections) {
 		drop_superfluous_outgoing_connection();
 	}
 
diff --git a/src/net.h b/src/net.h
index cf0ddc7..c6f45a7 100644
--- a/src/net.h
+++ b/src/net.h
@@ -122,6 +122,7 @@ typedef struct outgoing_t {
 	struct node_t *node;
 	int timeout;
 	timeout_t ev;
+	bool from_connectto;
 } outgoing_t;
 
 extern list_t *outgoing_list;
diff --git a/src/net_socket.c b/src/net_socket.c
index 206321c..85a928c 100644
--- a/src/net_socket.c
+++ b/src/net_socket.c
@@ -110,8 +110,8 @@ static bool bind_to_interface(int sd) {
 
 #if defined(SOL_SOCKET) && defined(SO_BINDTODEVICE)
 	memset(&ifr, 0, sizeof(ifr));
-	strncpy(ifr.ifr_ifrn.ifrn_name, iface, IFNAMSIZ);
-	ifr.ifr_ifrn.ifrn_name[IFNAMSIZ - 1] = 0;
+	strncpy(ifr.ifr_name, iface, IFNAMSIZ);
+	ifr.ifr_name[IFNAMSIZ - 1] = 0;
 
 	status = setsockopt(sd, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr));
 
@@ -210,8 +210,8 @@ int setup_listen_socket(const sockaddr_t *sa) {
 		struct ifreq ifr;
 
 		memset(&ifr, 0, sizeof(ifr));
-		strncpy(ifr.ifr_ifrn.ifrn_name, iface, IFNAMSIZ);
-		ifr.ifr_ifrn.ifrn_name[IFNAMSIZ - 1] = 0;
+		strncpy(ifr.ifr_name, iface, IFNAMSIZ);
+		ifr.ifr_name[IFNAMSIZ - 1] = 0;
 
 		if(setsockopt(nfd, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr))) {
 			closesocket(nfd);
@@ -841,6 +841,7 @@ void try_outgoing_connections(void) {
 			}
 
 			outgoing->node = n;
+			outgoing->from_connectto = true;
 			list_insert_tail(outgoing_list, outgoing);
 			setup_outgoing_connection(outgoing, true);
 		}
