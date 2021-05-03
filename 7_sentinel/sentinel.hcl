module "tfplan-functions" {
    source = "./common-functions/tfplan-functions/tfplan-functions.sentinel"
}

policy "enforce-vm-naming-convention" {
    source = "./vm_naming_convention.sentinel"
    enforcement_level = "hard-mandatory"
}
