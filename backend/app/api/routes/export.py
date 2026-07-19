import csv
import io

from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from openpyxl import Workbook
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle

from app.api.deps import require_owner
from app.services.github_service import github_service

router = APIRouter(prefix="/api/export", tags=["export"])

HEADERS = ["Order Number", "Tanggal", "Customer", "Total", "Status", "Metode Bayar"]


def _rows_from_orders(orders: list[dict]) -> list[list[str]]:
    return [
        [
            o["order_number"],
            o["created_at"],
            o["customer_name"],
            str(o["total"]),
            o["status"],
            o["payment_method"],
        ]
        for o in orders
    ]


@router.get("/orders.csv")
async def export_csv(claims: dict = Depends(require_owner)):
    orders = await github_service.read_json("orders.json", [])
    buf = io.StringIO()
    writer = csv.writer(buf)
    writer.writerow(HEADERS)
    writer.writerows(_rows_from_orders(orders))
    buf.seek(0)
    return StreamingResponse(
        iter([buf.getvalue()]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=orders.csv"},
    )


@router.get("/orders.xlsx")
async def export_xlsx(claims: dict = Depends(require_owner)):
    orders = await github_service.read_json("orders.json", [])
    wb = Workbook()
    ws = wb.active
    ws.title = "Orders"
    ws.append(HEADERS)
    for row in _rows_from_orders(orders):
        ws.append(row)
    buf = io.BytesIO()
    wb.save(buf)
    buf.seek(0)
    return StreamingResponse(
        buf,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": "attachment; filename=orders.xlsx"},
    )


@router.get("/orders.pdf")
async def export_pdf(claims: dict = Depends(require_owner)):
    orders = await github_service.read_json("orders.json", [])
    buf = io.BytesIO()
    doc = SimpleDocTemplate(buf, pagesize=A4)
    data = [HEADERS] + _rows_from_orders(orders)
    table = Table(data, colWidths=[28 * mm, 32 * mm, 30 * mm, 22 * mm, 24 * mm, 24 * mm])
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#1C1815")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTSIZE", (0, 0), (-1, -1), 8),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F5F1EA")]),
            ]
        )
    )
    doc.build([table])
    buf.seek(0)
    return StreamingResponse(
        buf,
        media_type="application/pdf",
        headers={"Content-Disposition": "attachment; filename=orders.pdf"},
    )
