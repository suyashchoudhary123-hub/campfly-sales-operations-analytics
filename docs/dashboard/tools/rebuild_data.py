"""Rebuild the public dataset: python tools/rebuild_data.py /path/to/source.xlsx"""
import json
import sys
from pathlib import Path
import pandas as pd

def main():
    if len(sys.argv) != 2:
        raise SystemExit('Usage: python tools/rebuild_data.py /path/to/source.xlsx')
    source = Path(sys.argv[1])
    sales = pd.read_excel(source, sheet_name='Sales Orders')
    customers = pd.read_excel(source, sheet_name='Customers')
    regions = pd.read_excel(source, sheet_name='Regions')
    products = pd.read_excel(source, sheet_name='Products')
    columns = ['OrderNumber', 'OrderDate', 'Ship Date', 'Customer Name Index',
               'Channel', 'Currency Code', 'Warehouse Code', 'Delivery Region Index',
               'Product Description Index', 'Order Quantity', 'Unit Price',
               'Total Unit Cost', 'Total Revenue']
    sales = sales[columns].copy()
    if sales.isna().any().any():
        raise ValueError('Missing sales values: review source before publishing')
    if sales.OrderNumber.duplicated().any():
        raise ValueError('Order grain changed: duplicate order numbers need model review')
    for foreign, dimension, key in [
        ('Customer Name Index', customers, 'Customer Index'),
        ('Delivery Region Index', regions, 'Index'),
        ('Product Description Index', products, 'Index')]:
        if dimension[key].duplicated().any() or not sales[foreign].isin(dimension[key]).all():
            raise ValueError('Duplicate dimension key or unmatched key: ' + foreign)
    if ((sales['Total Revenue'] - sales['Order Quantity']*sales['Unit Price']).abs() > .00001).any():
        raise ValueError('Revenue does not equal quantity times price')
    sales['OrderDate'] = pd.to_datetime(sales['OrderDate'])
    sales['Ship Date'] = pd.to_datetime(sales['Ship Date'])
    if ((sales['Ship Date'] - sales['OrderDate']).dt.days < 0).any():
        raise ValueError('Negative shipment lead time')
    if not sales['Currency Code'].isin(['NZD','USD','AUD','GBP','EUR']).all():
        raise ValueError('New currency: update website rates and filter options first')
    records = []
    for row in sales.itertuples(index=False, name=None):
        record = list(row)
        record[1] = row[1].strftime('%Y-%m-%d')
        record[2] = row[2].strftime('%Y-%m-%d')
        record.append(int((row[2]-row[1]).days))
        records.append(record)
    data = {
        'customers': [[int(r[0]),str(r[1]).strip()] for r in customers.itertuples(index=False,name=None)],
        'products': [[int(r[0]),str(r[1]).strip()] for r in products.itertuples(index=False,name=None)],
        'regions': [[int(r[0]),str(r[1]).strip(),str(r[2]).strip(),str(int(r[3])).zfill(4),float(r[4]),float(r[5]),str(r[6]).strip()] for r in regions.itertuples(index=False,name=None)],
        'orders': records
    }
    target = Path(__file__).resolve().parent.parent / 'data.js'
    target.write_text('/* Public when deployed. Review redistribution permission. */\nwindow.CAMPFLY = '+json.dumps(data,separators=(',',':'),ensure_ascii=False)+';\n',encoding='utf-8')
    print('Updated', target)
    print('Rows:',len(sales),'Order coverage:',sales.OrderDate.min().date(),'to',sales.OrderDate.max().date())
    print('Update hardcoded coverage/year/count labels if changed; rerun browser QA.')

if __name__ == '__main__':
    main()
