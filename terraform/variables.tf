variable "cloudflare_api_token" {
  description = "Cloudflare API Token with Tunnel, Access, and DNS permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for khangvum.com"
  type        = string
}

variable "domain" {
  description = "Base domain name"
  type        = string
  default     = "khangvum.com"
}

variable "tunnel_name" {
  description = "Name of the Cloudflare Zero Trust Tunnel"
  type        = string
  default     = "homelab-tunnel"
}

variable "allowed_emails" {
  description = "List of emails permitted through Zero Trust Access"
  type        = list(string)
}

variable "services" {
  description = "List of homelab services exposed through Cloudflare Tunnel"
  type = list(object({
    subdomain     = string
    scheme        = optional(string, "http") # Default to http if omitted
    ip            = string
    port          = number
    enable_access = bool
  }))
  default = []
}

variable "email_routing_map" {
  description = "Map of custom domain email prefixes to destination email addresses"
  type        = map(string)
}