import React from 'react';

interface Column<T> {
  header: string;
  accessor: keyof T | ((item: T) => React.ReactNode);
  className?: string;
  align?: 'left' | 'right' | 'center';
}

interface TableProps<T> {
  columns: Column<T>[];
  data: T[];
  onRowClick?: (item: T) => void;
  isLoading?: boolean;
  emptyMessage?: string;
}

export function Table<T>({
  columns,
  data,
  onRowClick,
  isLoading,
  emptyMessage = 'No data found',
}: TableProps<T>) {
  if (isLoading) {
    return (
      <div className="w-full py-xl flex justify-center items-center">
        <span className="material-symbols-outlined animate-spin text-primary text-[40px]">autorenew</span>
      </div>
    );
  }

  if (data.length === 0) {
    return (
      <div className="w-full py-xl flex flex-col justify-center items-center gap-md text-on-surface-variant">
        <span className="material-symbols-outlined text-[48px]">database_off</span>
        <p className="font-body-md">{emptyMessage}</p>
      </div>
    );
  }

  return (
    <div className="overflow-x-auto w-full">
      <table className="w-full text-left border-collapse">
        <thead>
          <tr className="bg-surface-container-low">
            {columns.map((column, index) => (
              <th
                key={index}
                className={`p-md font-label-lg text-label-lg text-on-surface-variant font-semibold ${
                  column.align === 'right' ? 'text-right' : column.align === 'center' ? 'text-center' : ''
                } ${column.className || ''}`}
              >
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="font-body-md text-body-md text-on-surface">
          {data.map((item, rowIndex) => (
            <tr
              key={rowIndex}
              onClick={() => onRowClick?.(item)}
              className={`hover:bg-surface-container-low transition-colors group border-b border-surface-container-high/50 last:border-0 ${
                onRowClick ? 'cursor-pointer' : ''
              }`}
            >
              {columns.map((column, colIndex) => (
                <td
                  key={colIndex}
                  className={`p-md ${
                    column.align === 'right' ? 'text-right' : column.align === 'center' ? 'text-center' : ''
                  } ${column.className || ''}`}
                >
                  {typeof column.accessor === 'function'
                    ? column.accessor(item)
                    : (item[column.accessor] as React.ReactNode)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
