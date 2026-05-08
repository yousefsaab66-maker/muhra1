import type { Currency } from "@/lib/catalog";
import type { GovernorateCode } from "@/lib/iraq";

export type BagItem = {
  productId: string;
  qty: number;
  size?: string;
};

export type OrderStatus =
  | "pending"
  | "preparing"
  | "shipped"
  | "delivered"
  | "cancelled";

/** حالياً: عند الاستلام فقط على الخادم. */
export type PaymentMethod = "cod";

export interface OrderCustomer {
  name: string;
  phone: string;
  governorate: GovernorateCode;
  city: string;
  address: string;
  notes?: string;
}

export interface OrderPayment {
  method: PaymentMethod;
  /** Legacy rows from older demo checkout versions. */
  cardLast4?: string;
  zaincashPhone?: string;
}

export interface Order {
  id: string;
  createdAt: string;
  customerName: string;
  customer?: OrderCustomer;
  items: { productId: string; name: string; qty: number; price: number; size?: string }[];
  subtotal: number;
  subtotalIqd?: number;
  shippingFeeIqd?: number;
  totalIqd?: number;
  currency: Currency;
  status: OrderStatus;
  payment?: OrderPayment;
}

export interface PlaceOrderInput {
  customer: OrderCustomer;
  payment: OrderPayment;
}
