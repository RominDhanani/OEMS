import React from 'react';
import { FaDownload } from 'react-icons/fa';

const TableControls = ({
    searchTerm,
    setSearchTerm,
    startDate,
    setStartDate,
    endDate,
    setEndDate,
    onDownload,
    placeholder = "Search...",
    downloadLabel = "Download Report",
    showDateFilters = true,
    showDownload = true,
    children
}) => {
    return (
        <div className="filter-bar">
            <div className="filter-group">
                <label>SEARCH</label>
                <input
                    type="text"
                    placeholder={placeholder}
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="filter-input"
                />
            </div>

            {showDateFilters && (
                <>
                    <div className="filter-group">
                        <label>START DATE</label>
                        <input
                            type="date"
                            value={startDate}
                            onChange={(e) => setStartDate(e.target.value)}
                            className="filter-input"
                        />
                    </div>
                    <div className="filter-group">
                        <label>END DATE</label>
                        <input
                            type="date"
                            value={endDate}
                            onChange={(e) => setEndDate(e.target.value)}
                            className="filter-input"
                        />
                    </div>
                </>
            )}

            {children}

            {showDownload && (
                <button
                    onClick={onDownload}
                    className="btn btn-primary filter-btn"
                    style={{ marginLeft: 'auto' }}
                >
                    <FaDownload /> {downloadLabel}
                </button>
            )}
        </div>
    );
};

export default TableControls;
