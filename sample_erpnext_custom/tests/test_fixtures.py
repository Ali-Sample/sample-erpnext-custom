import frappe
from frappe.tests import IntegrationTestCase


class TestFixtures(IntegrationTestCase):
	"""Process step o2c/quote/create: the sandbox reference field ships with the app."""

	def test_sandbox_reference_on_customer(self):
		field = frappe.get_meta("Customer").get_field("sandbox_reference")
		self.assertIsNotNone(field, "fixture not installed: Customer.sandbox_reference")
		self.assertEqual(field.fieldtype, "Data")
