# Enable Email Routing on public domain
# Known bug for >=5.23.0: https://github.com/cloudflare/terraform-provider-cloudflare/issues/7304
resource "cloudflare_email_routing_settings" "main" {
  zone_id = var.cloudflare_zone_id
}

# Add destination addresses
resource "cloudflare_email_routing_address" "destinations" {
  for_each   = toset(values(var.email_routing_map))
  account_id = var.cloudflare_account_id
  email      = each.value
}

# Create routing rules dynamically for every map key
resource "cloudflare_email_routing_rule" "rules" {
  for_each = var.email_routing_map

  zone_id = var.cloudflare_zone_id
  name    = "Forward ${each.key}@${var.domain}"
  enabled = true

  matchers = [{
    type  = "literal"
    field = "to"
    value = "${each.key}@${var.domain}"
  }]

  actions = [{
    type  = "forward"
    value = [cloudflare_email_routing_address.destinations[each.value].email]
  }]

  depends_on = [cloudflare_email_routing_settings.main]
}