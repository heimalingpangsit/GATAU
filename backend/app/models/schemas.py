from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


# ---------- Auth ----------
class UserRole(str, Enum):
    owner = "owner"
    kasir = "kasir"


class LoginRequest(BaseModel):
    username: str
    password: str


class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: UserRole
    username: str


class UserOut(BaseModel):
    username: str
    role: UserRole
    whatsapp: Optional[str] = None
    active: bool = True


# ---------- Menu ----------
class MenuItem(BaseModel):
    id: str
    name: str
    description: str = ""
    category: str = "kebab"
    price: int
    image_url: Optional[str] = None
    is_available: bool = True
    is_promo: bool = False
    created_at: Optional[str] = None
    updated_at: Optional[str] = None


class MenuItemCreate(BaseModel):
    name: str
    description: str = ""
    category: str = "kebab"
    price: int
    image_url: Optional[str] = None
    is_available: bool = True
    is_promo: bool = False


class MenuItemUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    price: Optional[int] = None
    image_url: Optional[str] = None
    is_available: Optional[bool] = None
    is_promo: Optional[bool] = None


# ---------- Voucher ----------
class VoucherType(str, Enum):
    percentage = "percentage"
    fixed = "fixed"


class Voucher(BaseModel):
    id: str
    code: str
    type: VoucherType
    value: int  # percentage (0-100) or fixed rupiah amount
    min_purchase: int = 0
    max_discount: Optional[int] = None
    quota: Optional[int] = None
    used_count: int = 0
    active: bool = True
    valid_from: Optional[str] = None
    valid_until: Optional[str] = None


class VoucherCreate(BaseModel):
    code: str
    type: VoucherType
    value: int
    min_purchase: int = 0
    max_discount: Optional[int] = None
    quota: Optional[int] = None
    active: bool = True
    valid_from: Optional[str] = None
    valid_until: Optional[str] = None


# ---------- Banner ----------
class Banner(BaseModel):
    id: str
    title: str
    image_url: str
    link_url: Optional[str] = None
    active: bool = True
    order: int = 0


class BannerCreate(BaseModel):
    title: str
    image_url: str
    link_url: Optional[str] = None
    active: bool = True
    order: int = 0


# ---------- Cart / Order ----------
class CartItemIn(BaseModel):
    menu_id: str
    qty: int = Field(gt=0)
    notes: str = ""


class CartItemOut(CartItemIn):
    name: str
    price: int
    subtotal: int


class CartOut(BaseModel):
    session_id: str
    items: list[CartItemOut]
    total: int


class CheckoutRequest(BaseModel):
    session_id: str
    customer_name: str
    customer_whatsapp: str
    order_type: str = "delivery"  # delivery | pickup
    address: Optional[str] = None
    voucher_code: Optional[str] = None
    payment_method: str = "qris"


class OrderStatus(str, Enum):
    pending_payment = "pending_payment"
    paid = "paid"
    processing = "processing"
    ready = "ready"
    completed = "completed"
    cancelled = "cancelled"
    expired = "expired"


class OrderItem(BaseModel):
    menu_id: str
    name: str
    price: int
    qty: int
    subtotal: int
    notes: str = ""


class Order(BaseModel):
    id: str
    order_number: str
    customer_name: str
    customer_whatsapp: str
    order_type: str
    address: Optional[str] = None
    items: list[OrderItem]
    subtotal: int
    discount: int = 0
    voucher_code: Optional[str] = None
    total: int
    payment_method: str = "qris"
    status: OrderStatus = OrderStatus.pending_payment
    pakasir_transaction_id: Optional[str] = None
    qris_url: Optional[str] = None
    created_at: str
    updated_at: str


class PakasirWebhookPayload(BaseModel):
    order_id: str
    status: str
    amount: Optional[int] = None
    transaction_id: Optional[str] = None
