
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from typing import Optional
from uuid import uuid4

app = FastAPI(
    title="BrightLoop API",
    description="Subscription Management System - User and Product Management",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

users = []
products = []


class RegisterUser(BaseModel):
    name: str
    email: str
    password: str


class LoginUser(BaseModel):
    email: str
    password: str


class Product(BaseModel):
    name: str
    product_type: str
    sales_price: float
    cost_price: float
    brand: str
    variant: Optional[str] = None
    notes: Optional[str] = None


@app.get("/")
def home():
    return {"message": "Welcome to BrightLoop API", "status": "running"}


@app.post("/register")
def register(user: RegisterUser):
    if any(u["email"] == user.email for u in users):
        raise HTTPException(status_code=400, detail="Email already registered")

    if len(user.password) < 8:
        raise HTTPException(status_code=400, detail="Password must contain at least 8 characters")

    new_user = {
        "id": str(uuid4()),
        "name": user.name,
        "email": user.email,
        "password": user.password,
        "role": "customer"
    }

    users.append(new_user)

    return {
        "message": "Registration successful",
        "user": {
            "id": new_user["id"],
            "name": new_user["name"],
            "email": new_user["email"],
            "role": new_user["role"]
        }
    }


@app.post("/login")
def login(user: LoginUser):
    existing_user = next(
        (u for u in users if u["email"] == user.email
         and u["password"] == user.password),
        None
    )

    if not existing_user:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    return {
        "message": "Login successful",
        "user": {
            "id": existing_user["id"],
            "name": existing_user["name"],
            "email": existing_user["email"],
            "role": existing_user["role"]
        }
    }


@app.get("/products")
def get_products():
    return products


@app.post("/products")
def add_product(product: Product):
    new_product = product.model_dump()
    new_product["id"] = str(uuid4())
    new_product["final_price"] = (
        new_product["sales_price"] + 560
        if new_product["brand"].lower() == "odoo"
        else new_product["sales_price"]
    )

    products.append(new_product)

    return {
        "message": "Product added successfully",
        "product": new_product
    }


@app.put("/products/{product_id}")
def update_product(product_id: str, product: Product):
    for index, existing in enumerate(products):
        if existing["id"] == product_id:
            updated = product.model_dump()
            updated["id"] = product_id
            updated["final_price"] = (
                updated["sales_price"] + 560
                if updated["brand"].lower() == "odoo"
                else updated["sales_price"]
            )
            products[index] = updated
            return {"message": "Product updated", "product": updated}

    raise HTTPException(status_code=404, detail="Product not found")


@app.delete("/products/{product_id}")
def delete_product(product_id: str):
    for product in products:
        if product["id"] == product_id:
            products.remove(product)
            return {"message": "Product deleted successfully"}

    raise HTTPException(status_code=404, detail="Product not found")


@app.get("/dashboard")
def dashboard():
    return {
        "total_users": len(users),
        "total_products": len(products),
        "total_product_value": sum(p["final_price"] for p in products)
    }
